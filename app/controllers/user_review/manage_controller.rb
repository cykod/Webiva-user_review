
class UserReview::ManageController < ModuleController

  component_info 'UserReview'

  permit 'user_review_manage'

  cms_admin_paths 'content', 
                  'User Reviews' => { :action => 'index' }
  



  active_table :user_review_table,
                UserReviewReview,
                [ :check,
                  :title,
                  hdr(:options,:container_node_id, :label => "Item", :options => :content_nodes, :display => 'select', :noun => 'Item'), 
                  hdr(:options,:approval,:options =>  [ ['Unrated',0],['Negative',-1],['Positive',1]],  :icon => 'icons/table_actions/rating_none.gif', :width => '32' ),
                  "User",
                  hdr(:options,:rating, :options => (1..5).to_a.map { |n| [ "#{n}", n ] }),
                  :created_at
                ]

    protected

    def content_nodes
      UserReviewReview.content_node_select_options.sort { |a,b| a[0].to_s.downcase <=> b[0].to_s.downcase }
    end


    public


  def display_user_review_table(display=true)
    active_table_action 'user_review' do |act,ids|
      case act
      when 'delete':
        UserReviewReview.destroy ids
      when 'approve'
        UserReviewReview.find(ids).map(&:publish!)
      end
    end

    @tbl = user_review_table_generate params, :order => 'created_at DESC'

    render :partial => 'user_review_table' if display
  end


  def index
    cms_page_path ['Content'], 'User Reviews'
    display_user_review_table(false)
  end

 
  def edit
    @review = UserReviewReview.find(params[:path][0]) || UserReviewReview.new
    cms_page_path ['Content', 'User Reviews'], @review.id ? 'Edit Review' : 'Create Review'

    if request.post? 
      if params[:commit] && @review.update_attributes(params[:user_review])
        flash[:notice] = "Review Saved"
        redirect_to :action => 'index'
      else
        redirect_to :action => 'index'
      end
    end

  end



end
