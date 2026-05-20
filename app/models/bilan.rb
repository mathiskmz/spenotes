class Bilan < ApplicationRecord
  belongs_to :patient
  belongs_to :user

  has_many_attached :files
end
