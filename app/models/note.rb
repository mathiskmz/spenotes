class Note < ApplicationRecord
  belongs_to :patient
  belongs_to :user
  has_many :attachments, dependent: :destroy
end
