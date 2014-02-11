require 'yaml'
require 'erb'
require 'dalli'
require 'active_model'
require 'active_model/callbacks'
require 'active_support/hash_with_indifferent_access'
require 'active_support/concern'
module Mor

  def self.env
    ENV['RACK_ENV'] ||= "development"
  end
  
  def self.cache=cache
    @@cache=cache
  end
    
  def self.cache
    @@cache ||= begin
      config = YAML::load(ERB.new(File.read("config/cache.yml")).result)[Mor.env]
      @instance = Dalli::Client.new config.delete("servers").split(","), config
    end
  end

  extend ActiveSupport::Concern
  extend  ActiveModel::Callbacks    
      
  module ClassMethods

    def attr_accessor *attrs
      super(*attrs)
      attrs.delete_if{ |a| a == :attributes }.each { |attr| 
        define_method(:"#{attr}="){|val| self.attributes[attr]=val}
        define_method(attr){ self.attributes[attr] }            
      }
    end
    
    def key id = primary_key
      :"#{self.name.downcase}:#{id}"
    end
    
    def primary_key
      :id
    end
    
    def create attributes = {}
      instance = self.new(attributes)
      instance.save
      instance
    end
    
  end

  included do
    include ActiveModel::Model
    extend  ActiveModel::Callbacks    
    include ActiveModel::Validations::Callbacks
    define_model_callbacks :create, :update, :destroy
    after_create :add_to_index
    after_destroy :remove_from_index
    validates_presence_of :id
    validate :validate_uniqueness_of_id
  end
  
  def attributes
    @attributes ||= ActiveSupport::HashWithIndifferentAccess.new
  end
  
  def initialize attributes = {}
    self.attributes ||= ActiveSupport::HashWithIndifferentAccess.new(attributes)
  end
  
  def update attributes={}    
    self.attributes.update attributes
    save
  end
  
  def save
    if self.valid?
      if self.persisted?
        run_callbacks :update do
          cache.set(self.key,self)
        end
      else
        run_callbacks :create do
          cache.set(self.key,self)
        end
      end
    end
  end
  
  def destroy 
    run_callbacks :destroy do
      cache.delete key
    end    
  end
  
  def key
    self.class.key self.id
  end
  
  def persisted?
    self.indexed?
  end
  
  def id
    self.attributes[self.class.primary_key]
  end
  
  # index 
  
  def indexed?
    @indexed ||= index.include?(self.id)
  end
  
  def index
    @index ||= begin
      cache.get(self.class.key) || (self.index=[])
    end
  end
  
  def index=index
    @index = begin
      cache.set(self.class.key,index) ? index : []
    end
  end
  
  private
  
  def add_to_index
    self.index = index.push(self.id)
  end
  
  def remove_from_index
    self.index = index.tap{ |index| index.delete(self.id) }
  end
  
  def validate_uniqueness_of_id
    self.errors.add(:id, :taken) if indexed?
  end
  
  def cache
    Mor.cache
  end

  
end
