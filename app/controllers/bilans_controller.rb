class BilansController < ApplicationController
  before_action :set_patient
  before_action :set_bilan, only: [ :edit, :update, :remove_file ]

  def new
    redirect_to edit_patient_bilan_path(@patient) if @patient.bilan.present?
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
