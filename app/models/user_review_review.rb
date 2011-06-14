

class UserReviewReview < DomainModel

  validates_presence_of :title
  validates_length_of :review_body, :minimum => 50, :message => 'must be at least 50 characters long'

  belongs_to :end_user
  belongs_to :user_review_type

  after_save :save_content_model
  after_save :save_user_review_result
  before_create :generate_permalink

  before_destroy :destroy_model

  belongs_to :container_node, :class_name => 'ContentNode'

  content_node :container_type => 'UserReviewType',  :container_field => :user_review_type_id, :push_value => true,  :published => Proc.new { |o| o.approval > 0 }

  has_options :approval, [['Rejected',-1],['Unmoderated',0],['Approved',1]]

  named_scope :by_container_node, Proc.new { |node_id| { :conditions => { :container_node_id => node_id } } }
  named_scope :approved, { :conditions => [ 'approval > 0' ] }

  def validate
    self.errors.add_to_base('Please select a product') if !self.container_node
    self.errors.add_to_base("Overall rating can't be blank") if self.rating.blank?
    if @content_model_entry
      self.errors.add_to_base('Review Details Error') if !@content_model_entry.valid?  
    end
  end

  def content_description(language)
    "User Review"
  end

  def content_model
    self.user_review_type.content_model if self.user_review_type
  end

  def model_data=(val)
    self.model.attributes = val
  end

  def self.content_node_select_options
    reviews = UserReviewReview.find(:all,:select => 'container_node_id',:group => 'container_node_id')


    ContentNodeValue.all(:select => "title,content_node_id", :conditions => { :content_node_id => reviews.map(&:container_node_id) }).map { |c| [ c.name, c.content_node_id ]  }
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

  def save_user_review_result
    UserReviewResult.push_review(self)
  end

  def generate_permalink
     self.permalink = generate_url(:permalink,self.title.to_s.strip)
  end
  
  def publish!
    self.update_attributes(:approval => 1)
  end

  def destroy_model
    self.model.destroy if self.model.id
  end

  def rating_icon(override=nil)
    override = approval unless override
    if override == 0
      'icons/table_actions/rating_none.gif'
    elsif override > 0
      'icons/table_actions/rating_positive.gif'
    else 
      'icons/table_actions/rating_negative.gif'
    end
  end

end
