class OwnerRequestEvent < ApplicationRecord
  belongs_to :owner_request
  belongs_to :actor, class_name: "User", optional: true

  validates :action, presence: true
end
