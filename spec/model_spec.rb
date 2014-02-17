require 'minitest_helper'
require 'mor/model'

class TestModel
  include Mor::Model
  attr_accessor :id, :title, :body, :slug
  validates_presence_of :slug
  before_validation :set_slug 
  private
  def set_slug
    self.slug = title.downcase
  end
end

class TestModelDiffPK
  include Mor::Model
  def self.primary_key
    :slug
  end
  attr_accessor :slug, :title, :body, :slug
  before_validation :set_slug 
  private
  def set_slug
    self.slug = title.downcase
  end
end

describe Mor::Model do
  
  it "acts as active_model/model" do
    instance = TestModel.new(title: "title", body: "test body")
    instance.title.must_equal "title"
    instance.body.must_equal "test body"
  end
  
  it "stores attribute data in @attributes instance var" do
    instance = TestModel.new(title: "title", body: "test body")
    instance.attributes[:title].must_equal "title"
    instance.attributes[:body].must_equal "test body"
  end
  
  it "validates id as a primary key by default" do
    instance = TestModel.new(title: "title", body: "test body")
    instance.valid?.must_equal false
    instance.id = "test-id"
    instance.valid?.must_equal true 
  end
  
  it "indexes record's id on save and unindexes on destroy" do
    instance = TestModel.create(id: "test-id", title: "title", body: "test body")
    TestModel.index.must_include "test-id"    
    instance.destroy
    TestModel.index.must_be_empty
  end

  it "provides basic CRUD" do
    instance = TestModel.create(id: "test-id", title: "title", body: "test body")
    instance.valid?.must_equal true 
    instance.persisted?.must_equal true
    TestModel.find("test-id").title.must_equal "title"
    TestModel.all.collect(&:id).must_equal [instance.id]
    instance.destroy
    TestModel.all.must_be_empty
    TestModel.index.must_be_empty
    TestModel.find("test-id").must_be_nil
  end
  
  it "can has different primary key than id" do
    instance = TestModelDiffPK.create(title: "Tett Name")
    instance.persisted?.must_equal true
    instance.id.must_equal instance.slug
    instance.attributes[:id].must_equal instance.attributes[:slug]
  end
  
  it "finds single record by attributes" do
    instance = TestModel.create(id: "test-id", title: "title", body: "test body")
    TestModel.find_by(title: "title").attributes.must_equal instance.attributes
  end
  
  it "finds many records by attributes" do
    instance = TestModel.create(id: "test-id", title: "title", body: "test body")
    instance2 = TestModel.create(id: "test-id-2", title: "title", body: "test body")    
    TestModel.where(title: "title").size.must_equal 2
  end
  
end