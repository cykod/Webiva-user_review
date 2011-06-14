

class UserReviewFeature

  def self.site_feature_blog_entry_list_handler_info
    { 
      :name => 'Rating Content'
    }
   end

  def self.blog_entry_list_feature(c,data)
    c.expansion_tag('entry:reviews') do  |t|
       t.locals.review = UserReviewResult.by_container_node_id(t.locals.entry.content_node.id).first
    end

    c.value_tag('entry:reviews:num') { |t| t.locals.review.num_ratings }
    c.value_tag('entry:reviews:stars') {  |t| t.locals.review.rating_stars}

    c.value_tag('entry:reviews:rating') do |t| 
      if t.attr['multiplier'] 
        (t.locals.review.rating * (t.attr['multiplier'] || 1).to_i).floor.to_i 
      else
        sprintf("%0.1f",t.locals.review.rating)
      end
    end
  end

    def self.site_feature_blog_entry_detail_handler_info
    { 
      :name => 'Rating Content'
    }
   end

  def self.blog_entry_detail_feature(c,data)
    self.blog_entry_list_feature(c,data)
  end


end
