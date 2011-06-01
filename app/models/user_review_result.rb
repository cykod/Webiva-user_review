


class UserReviewResult < DomainModel



  def self.push_review(review)
    result = UserReviewResult.find_by_container_node_id_and_user_review_type_id(review.container_node_id,
                                                                                review.user_review_type_id) ||
             UserReviewResult.new(:container_node_id => review.container_node_id,                                                                   :user_review_type_id => review.user_review_type_id)

    result.update_results
  end

  def update_results
    self.num_ratings = UserReviewReview.count(:conditions => { :container_node_id => self.container_node_id, :approval => 1 })
    self.rating_stars = UserReviewReview.sum(:rating,:conditions => { :container_node_id => self.container_node_id, :approval => 1 })

    self.rating = self.num_ratings > 0 ? self.rating_stars / self.num_ratings  : 0 
    self.save
  end

end
