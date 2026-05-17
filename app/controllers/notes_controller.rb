class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy, :add_files, :remove_file]

  def index
    # includes(:patient) évite le problème N+1 : sans ça, Rails ferait une requête SQL
    # par note pour récupérer le patient associé (ex : 50 notes = 51 requêtes).
    @notes = current_user.notes.includes(:patient).order(created_at: :desc)
  end

  def show; end

  def new
    if params[:patient_id].present?
      # Route imbriquée (/patients/:id/notes/new) : patient déjà connu
      @patient = current_user.patients.find(params[:patient_id])
    else
      # Route standalone (/notes/new) : le patient sera choisi dans le formulaire
      @patients = current_user.patients.order(:name)
    end
    @note = Note.new
  end

  def create
    # Déterminer le patient : existant (select ou URL imbriquée) ou nouveau (champs inline)
    if params[:patient_id].present?
      @patient = current_user.patients.find(params[:patient_id])
    elsif params[:new_patient_name].present?
      @patient = current_user.patients.create(
        name: params[:new_patient_name],
        age: params[:new_patient_age].presence,
        pathology: params[:new_patient_pathology].presence
      )
      unless @patient.persisted?
        @note = Note.new(note_params)
        @patients = current_user.patients.order(:name)
        render :new, status: :unprocessable_entity and return
      end
    else
      @note = Note.new(note_params)
      @patients = current_user.patients.order(:name)
      flash.now[:alert] = "Veuillez sélectionner un patient existant ou renseigner un nouveau."
      render :new, status: :unprocessable_entity and return
    end

    # build() construit la note et renseigne automatiquement patient_id.
    # On doit ensuite assigner user_id manuellement car la note a deux clés étrangères.
    @note = @patient.notes.build(note_params)
    @note.user = current_user
    if @note.save
      redirect_to note_path(@note), notice: "Note enregistrée."
    else
      @patients = current_user.patients.order(:name) if @patients.nil?
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @note.update(note_params)
      redirect_to note_path(@note), notice: "Note mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def add_files
    blobs = Array(params[:files]).reject(&:blank?)
    @note.files.attach(blobs) if blobs.any?
    redirect_to note_path(@note)
  end

  def remove_file
    attachment = @note.files.attachments.find(params[:attachment_id])
    attachment.purge
    redirect_to note_path(@note)
  end

  def destroy
    # On sauvegarde la référence au patient avant la suppression :
    # après @note.destroy, @note.patient ne serait plus accessible.
    patient = @note.patient
    @note.destroy
    redirect_to patient_path(patient), notice: "Note supprimée."
  end

  private

  def set_note
    @note = current_user.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content, :important)
  end
end
