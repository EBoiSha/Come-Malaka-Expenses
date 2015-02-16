class Item
	include Mongoid::Document
  include Authority::Abilities
  resourcify

  #uses ItemAuthorizer by default

  require 'open-uri'

	field :name, type: String
	field :value_date, type: Date
	field :description, type: String
	belongs_to :event
  field :base_amount, type: BigDecimal
  field :base_currency, type: String
  field :exchange_rate, type: BigDecimal
  field :foreign_amount, type: BigDecimal
  field :foreign_currency, type: String
  belongs_to :payer, class_name: "User"
  has_and_belongs_to_many :beneficiaries, class_name: "User", inverse_of: nil

  #apply exchange rate must be validated before numericality
  validate :apply_exchange_rate
  validates :name, :description, :value_date, :event, :base_currency, 
    :foreign_currency, :payer, :beneficiaries, presence: true
  #validates :beneficiaries, presence: true, message: "You must choose at least one beneficiary."
  validates :foreign_amount, :exchange_rate, numericality: {greater_than: 0}
  
  
  after_save :initialize_roles

  after_destroy :revoke_roles

  def initialize_roles
    self.event.users.each do |participant|
      initialize_role_for participant
    end
  end

  def revoke_roles
    self.event.users.each do |participant|
      revoke_role_for participant
    end
  end

  def initialize_role_for participant
    participant.add_role(:event_participant, self) unless participant.has_role?(:event_participant, self)
  end

  def revoke_role_for participant
    participant.revoke(:event_participant, self) if participant.has_role?(:event_participant, self)
  end

  def cost_per_beneficiary
    self.base_amount / self.beneficiaries.count
  end

  def apply_exchange_rate
    if self.exchange_rate.blank? then
      self.exchange_rate = JSON.parse(open("http://devel.farebookings.com/api/curconversor/" + self.foreign_currency + "/" + self.base_currency + "/1/json").read)[self.base_currency].to_d
      self.rate_changed = true
    end
    self.base_amount = self.foreign_amount * self.exchange_rate
  rescue Timeout::Error
    self.errors[:exchange_rate] = " cannot get exchange rate (Timed Out). If problem persists try to type a rate manually."
    self.rate_changed = false
  rescue
    self.errors[:exchange_rate] = " cannot get exchange rate. If problem persists try to type a rate manually."
    self.rate_changed = false
  end

  attr_accessor :rate_changed
  alias_method :rate_changed?, :rate_changed

end