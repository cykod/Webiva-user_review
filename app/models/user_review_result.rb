


class UserReviewResult < DomainModel


  belongs_to :container_node, :class_name => 'ContentNode'

  named_scope(:by_container_node_id, Proc.new { |nid| { :conditions => { :container_node_id => nid } } })


  def self.push_review(review)
    result = UserReviewResult.find_by_container_node_id_and_user_review_type_id(review.container_node_id,
                                                                                review.user_review_type_id) ||
             UserReviewResult.new(:container_node_id => review.container_node_id,                                                                   :user_review_type_id => review.user_review_type_id)

    result.update_results
  end

  def update_results
    self.num_ratings = UserReviewReview.count(:conditions => { :container_node_id => self.container_node_id, :approval => 1 })
    self.rating_stars = UserReviewReview.sum(:rating,:conditions => { :container_node_id => self.container_node_id, :approval => 1 })

    self.rating = self.num_ratings > 0 ? self.rating_stars.to_f / self.num_ratings.to_f  : 0 
    self.save

    if self.container_node && node = self.container_node.node 
      node.update_attribute(:rating,self.rating) if node.respond_to?(:rating=)
    end
  end

end
