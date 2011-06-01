

class UserReviewType < DomainModel

  belongs_to :content_model
  belongs_to :content_model_field

  validates_presence_of :content_model
  validates_presence_of :name


  content_node_type :user_review, "UserReviewReview", :content_name => :name,:title_field => :title, :url_field => :permalink 

  def content_type_name
    "User Review Type"
  end


  def content_admin_url(node)
    { :controller => "/user_review/manage",:action => 'edit', :path => [ node  ] }
  end

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

  def content_detail_link_url(path,user_review)
    if user_review.content_node && 
      user_review.content_node.node && 
      user_review.content_node.node.respond_to?(:permalink)
      SiteNode.link(path, user_review.container_node.node.permalink, user_review.permalink)
    else
      SiteNode.link(path,user_review.permalink)
    end
  end

end
