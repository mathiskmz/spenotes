class VocabulariesController < ApplicationController
  CATEGORIES = ["Anatomie", "Pathologies", "Latin", "Traitement", "Mes termes"].freeze

  def index
    @vocabularies = current_user.vocabularies.order(:category, :input)
    @vocabularies = @vocabularies.where(category: params[:category]) if params[:category].present?
    @vocabulary = Vocabulary.new
    @categories = CATEGORIES
  end

  def create
    @vocabulary = current_user.vocabularies.build(vocabulary_params)
    if @vocabulary.save
      redirect_to vocabularies_path, notice: "Terme ajouté."
    else
      @vocabularies = current_user.vocabularies.order(:category, :input)
      @categories = CATEGORIES
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @vocabulary = current_user.vocabularies.find(params[:id])
    @vocabulary.destroy
    redirect_to vocabularies_path, notice: "Terme supprimé."
  end

  private

  def vocabulary_params
    params.require(:vocabulary).permit(:input, :output, :category)
  end
end
