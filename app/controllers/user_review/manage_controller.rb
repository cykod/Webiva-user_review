
class UserReview::ManageController < ModuleController

  component_info 'UserReview'

  permit 'user_review_manage'


  active_table :user_reviews_table,
                UserReviewReview,
                [ :check,
                  :title,
                  "Item",
                  hdr(:options,:approval,:options =>  [ ['Unrated',0],['Negative',-1],['Positive',1]],  :icon => 'icons/table_actions/rating_none.gif', :width => '32' ),
                  "User",
                  hdr(:options,:rating, :options => [ 1,2,3,4,5 ])
                ]


  def display_user_reviews_table(display=true)
    active_table_action 'review' do |act,ids|
      case 'act'
      when 'delete':
        UserReviewReview.destroy ids
      when 'publish'
        UserReviewReview.find(ids).map(&:publish!)
      end
    end

    @tbl = user_reviews_table_generate params, :order => 'created_at DESC'

    render :partial => 'user_reviews_table' if display
  end


  def index
    display_user_reviews_table(false)
  end

 
  def edit

    @review = UserReviewReview.find(params[:path][0]) || UserReviewReview.new

    if @review.update_attributes(params[:user_review])
      redirect_to :action => 'index'
    end

  end



end
