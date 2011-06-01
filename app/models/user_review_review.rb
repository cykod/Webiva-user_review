

class UserReviewReview < DomainModel

  validates_presence_of :title, :review_body


  belongs_to :user_review_type

  after_save :save_content_model
  before_create :generate_permalink

  belongs_to :container_node, :class_name => 'ContentNode'

  content_node :container_type => 'UserReviewType',  :container_field => :user_review_type_id, :push_value => true, :published_at => :published_at, :published => Proc.new { |o| o.approval > 0 }


  named_scope :by_container_node, Proc.new { |node_id| { :conditions => { :container_node_id => node_id } } }
  named_scope :approved, { :conditions => [ 'approval > 0' ] }

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
  
  def publish!
    self.update_attributes(:approval => 1)
  end

end
