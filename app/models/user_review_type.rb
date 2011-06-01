

class UserReviewType < DomainModel

  belongs_to :content_model
  belongs_to :content_model_field

  validates_presence_of :content_model
  validates_presence_of :name


  content_node_type :user_review, "UserReviewReview", :content_name => :name,:title_field => :title, :url_field => :permalink, :except => Proc.new { |blg| blg.is_user_blog? }
 

  def validate
    if self.content_model

      self.content_model_field = self.content_model.content_model_fields.detect { |f| f.field_type == 'belongs_to' &&  f.relation_class_name == 'Other' }

      if self.content_model_field.blank?
        self.errors.add(:content_mdoel_id,'must have a valid belongs_to field') 
      else
        self.relation_field = self.content_model_field.field
      end
    end
  end

  def content_detail_link_url(path,obj)
    obj.content_node
  end




end
