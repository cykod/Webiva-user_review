

class UserReviewReview < DomainModel

  validates_presence_of :title, :review_body


  belongs_to :user_review_type

  after_save :save_content_model
  before_create :generate_permalink

  named_scope :by_content_node, Proc.new { |node_id| { :conditions => { :content_node_id => node_id } } }


  def validate
    if @content_model_entry
      self.errors.add_to_base('Model error') if !@content_model_entry.valid?  
    end
  end

  def content_model
    self.user_review_type.content_model
  end

  def model_data=(val)
    self.model.attributes = val
  end

 def model
    return @content_model_entry if @content_model_entry
    return nil unless self.content_model

    cls = self.content_model.model_class
    model_attributes = { self.user_review_type.relation_field => self.id }

    @content_model_entry = cls.find(:first,:conditions => model_attributes)
    unless @content_model_entry
      @content_model_entry = cls.new(model_attributes)
    end

    @content_model_entry
  end


  def save_content_model
    if @content_model_entry
      @content_model_entry.attributes =  { self.user_review_type.relation_field => self.id }
      @content_model_entry.save
    end
  end

  def generate_permalink
     self.permalink = generate_url(:permalink,self.title.to_s.strip)
  end

end
