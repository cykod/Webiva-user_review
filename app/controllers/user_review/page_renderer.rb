class UserReview::PageRenderer < ParagraphRenderer

  features '/user_review/page_feature'

  paragraph :list
  paragraph :submit
  paragraph :detail

  def list
    @options = paragraph_options :list

    # Any instance variables will be sent in the data hash to the 
    # user_review_page_list_feature automatically
    #

    if editor?
      @reviews = UserReviewReview.paginate(params[:page])
    else
      conn_type,conn_id = page_connection
      @reviews = UserReviewReview.paginate(params[:page],{ :order => 'created_at DESC'},UserReviewReview.by_content_node(conn_id))
    end

  
    render_paragraph :feature => :user_review_page_list
  end

  def submit
    @options = paragraph_options :submit


    if editor?
      node = ContentNode.find(:first)
    else
      conn_type,conn_id = page_connection

      node = ContentNode.find_by_id(conn_id)
    end
   
    @review = UserReviewReview.new({ :end_user_id => myself.id, 
                                     :user_review_type_id => @options.user_review_type_id,
                                     :content_node_id => node.id })
    require_js('prototype')

    if request.post? && params[:review]
      if @review.update_attributes(params[:review].slice(:title,:review_body,:rating,:model_data))
        # if we're not logged in, redirect to user login page, set session and review

        # if we are logged in, redirect to the thank you page
        # handle trigered actions

      end
    end
  
    render_paragraph :feature => :user_review_page_submit
  end

  def detail
    @options = paragraph_options :detail


    # Any instance variables will be sent in the data hash to the 
    # user_review_page_detail_feature automatically
  
    render_paragraph :feature => :user_review_page_detail
  end

end
