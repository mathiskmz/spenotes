class VocabulariesController < ApplicationController
  CATEGORIES = ["Anatomie", "Pathologies", "Latin", "Traitement", "Mes termes"].freeze
  LIMIT = 25
  def index
    @vocabularies = current_user.vocabularies.order(:category, :input)
    @vocabularies = @vocabularies.where(category: params[:category]) if params[:category].present?
    @vocabulary = Vocabulary.new
    @categories = CATEGORIES
    @limit = LIMIT
    @base_keywords = ::WhisperService::KINE_BASE_PROMPT.split(",").map(&:strip).reject(&:blank?)
  end

  def create
    if current_user.vocabularies.count < LIMIT
      @vocabulary = current_user.vocabularies.build(vocabulary_params)
      if @vocabulary.save
        redirect_to vocabularies_path, notice: "Terme ajouté."
      else
        @vocabularies = current_user.vocabularies.order(:category, :input)
        @categories = CATEGORIES
        render :index, status: :unprocessable_entity
      end
    else
      redirect_to vocabularies_path, notice: "Limite de vocabulaire atteinte"
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
