require 'active_model'
require 'active_support/concern'
require 'active_support/hash_with_indifferent_access'

module Mor
  module Model
    
    module ClassMethods
      
      def attr_accessor *attrs
        super(*attrs)
        attrs.delete_if{ |a| a == :attributes }.each { |attr| 
          define_method(:"#{attr}="){|val| self.attributes[attr]=val}
          define_method(attr){ self.attributes[attr] }            
        }
      end
      
      def key primary_key=self.primary_key
        :"#{self.name}:#{primary_key}"
      end
      
      def primary_key
        :id
      end
      
      def create attributes = {}
        instance = self.new(attributes)
        instance.save
        instance
      end
      
      def index
        Mor.cache.get(self.key) || (self.index=[])
      end
      
      def index=index
        Mor.cache.set(self.key,index) ? index : []
      end
      
      def find id
        self.deserialize(Mor.cache.get(key(id)))
      end
      
      def all
        self.index.map{|id| find(id) }
      end
      
      def serialize object
        object
      end
      
      def deserialize object
        object
      end      
      
    end
      
    extend ActiveSupport::Concern
    
    included do
      
      include ActiveModel::Model      
      extend ActiveModel::Callbacks     
      include ActiveModel::Validations      
      include ActiveModel::Validations::Callbacks
                
      define_model_callbacks :save, :create, :update, :destroy
      
      validates_presence_of :id
      validate :validate_uniqueness_of_id, unless: "persisted?"
      after_create :add_to_index
      after_destroy :remove_from_index
    
      def persisted?
        self.id.nil? ? false : self.class.index.include?(self.id)
      end
      
    end
    
    def attributes
      @attributes ||= ActiveSupport::HashWithIndifferentAccess.new
    end
    
    def attributes= attributes
      @attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes)
    end
    
    def key
      self.class.key(self.id)
    end
    
    def id
      self.attributes[self.class.primary_key]
    end
    
    def id=val
      self.attributes[self.class.primary_key]=val
    end
    
    # CRUD
    
    def update attributes = {}
      self.attributes.update attributes
      self.save
    end
    
    def save
      if self.valid?
        save_or_update
      end
    end
    
    def destroy
      run_callbacks :destroy do
        Mor.cache.delete(self.key)
      end
    end
    
    private
    
    def validate_uniqueness_of_id
      errors.add(:id, :taken) if self.class.index.include?(self.id)
    end
    
    def save_or_update
      if self.persisted?
        run_callbacks :update do
          save_to_cache
        end
      else
        run_callbacks :create do
          save_to_cache
        end
      end
    end
    
    def add_to_index
      self.class.index = self.class.index.push(self.id)
    end
    
    def remove_from_index
      self.class.index = self.class.index.tap{ |ids| ids.delete(self.id) } 
    end
    
    def save_to_cache
      run_callbacks :save do
        Mor.cache.set(self.key,self.class.serialize(self))
      end
    end
    
  end
end