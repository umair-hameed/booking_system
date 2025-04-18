class AuditLog < ApplicationRecord
  belongs_to :booking

  validates :action, :timestamp, presence: true
end
