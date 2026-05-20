class Patient < ApplicationRecord
  belongs_to :user
  has_many :notes, dependent: :destroy
  has_one :bilan, dependent: :destroy
  has_many_attached :files
end
