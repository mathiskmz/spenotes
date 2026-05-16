class PatientsController < ApplicationController
  before_action :set_patient, only: [:show, :edit, :update, :destroy]

  def index
    @patients = current_user.patients.order(updated_at: :desc)
    # 1.week.ago.. est une "endless range" Ruby : de il y a 7 jours jusqu'à maintenant (sans borne de fin).
    @notes_this_week = current_user.notes.where(created_at: 1.week.ago..).count
  end

  def show
    @notes = @patient.notes.order(created_at: :desc)
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = current_user.patients.build(patient_params)
    if @patient.save
      redirect_to patients_path, notice: "Patient ajouté."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @patient.update(patient_params)
      redirect_to patient_path(@patient), notice: "Patient mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @patient.destroy
    redirect_to patients_path, notice: "Patient supprimé."
  end

  private

  def set_patient
    # On cherche dans current_user.patients et non Patient.find — sécurité : un utilisateur
    # ne peut pas accéder aux patients d'un autre, même en modifiant l'URL.
    @patient = current_user.patients.find(params[:id])
  end

  def patient_params
    params.require(:patient).permit(:name, :age, :pathology)
  end
end
