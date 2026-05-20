class BilansController < ApplicationController
  before_action :set_patient
  before_action :set_bilan, only: [ :show, :edit, :update, :remove_file, :upload_chunk, :add_manual_note, :finalize, :regenerate_summary, :regenerate_recommendations ]

  def show; end

  # Page d'enregistrement audio — crée le bilan s'il n'existe pas encore
  def recording
    @bilan = @patient.bilan || @patient.create_bilan!(user: current_user)
  end

  def new
    redirect_to edit_patient_bilan_path(@patient) and return if @patient.bilan.present?
    @bilan = @patient.build_bilan
  end

  def create
    @bilan = @patient.build_bilan(bilan_params)
    @bilan.user = current_user
    if @bilan.save
      redirect_to patient_path(@patient), notice: "Bilan enregistré."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @bilan.update(bilan_params)
      redirect_to patient_path(@patient), notice: "Bilan mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def remove_file
    attachment = @bilan.files.attachments.find(params[:attachment_id])
    attachment.purge
    redirect_to edit_patient_bilan_path(@patient)
  end

  # Reçoit un chunk audio du navigateur, le transcrit via Whisper et l'ajoute à la transcription brute
  def upload_chunk
    audio_blob = params[:audio_chunk]

    unless audio_blob
      return render json: { error: "Aucun audio reçu" }, status: :bad_request
    end

    # On met à jour le statut et la durée
    chunk_duration = params[:chunk_duration].to_i
    @bilan.update!(status: "recording", duration_seconds: @bilan.duration_seconds + chunk_duration)

    vocabulary = current_user.vocabularies
    begin
      segment = WhisperService.call(audio_blob.tempfile, vocabulary: vocabulary)
      @bilan.append_transcription!(segment) if segment.present?
      render json: { ok: true, segment: segment }
    rescue Faraday::TimeoutError, Faraday::Error => e
      Rails.logger.error "[upload_chunk] Whisper error: #{e.message}"
      render json: { ok: false, error: "Transcription indisponible pour ce chunk" }
    end
  end

  # Reçoit une note manuelle saisie pendant l'écoute (active ou en pause)
  def add_manual_note
    text = params[:text].to_s.strip
    timestamp = params[:timestamp_seconds].to_i

    return render json: { error: "Texte vide" }, status: :bad_request if text.blank?

    @bilan.add_manual_note!(text, timestamp)

    render json: { ok: true }
  end

  # Déclenche la synthèse IA et redirige vers la page de résultat
  def regenerate_summary
    @bilan.update!(summary: nil)
    SummaryJob.perform_later(@bilan.id)
    render json: { ok: true }
  end

  def regenerate_recommendations
    @bilan.update!(recommendations: nil)
    RecommendationsJob.perform_later(@bilan.id)
    render json: { ok: true }
  end

  def finalize
    @bilan.update!(status: "processing")
    SynthesisJob.perform_later(@bilan.id)

    render json: { ok: true, redirect_url: patient_path(@patient) }
  end

  private

  def set_patient
    @patient = current_user.patients.find(params[:patient_id])
  end

  def set_bilan
    @bilan = @patient.bilan
    redirect_to new_patient_bilan_path(@patient) unless @bilan
  end

  def bilan_params
    params.require(:bilan).permit(:content, files: [])
  end
end
