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
    path_conn_type,@content_path = page_connection(:content_path)

    conn_type,conn_review = page_connection(:path)
    return render_paragraph :text => '' if !conn_review.blank?

    if editor?
      @pages,@reviews = UserReviewReview.paginate(params[:page], :per_page => @options.per_page)
    else
      conn_type,conn_id = page_connection
      return render_paragraph :text => '' if conn_id.blank? && conn_type.present?
      scope = path_conn_type ? UserReviewReview.by_container_node(conn_id) : UserReviewReview
      @pages,@reviews = scope.approved.paginate(params[:page], :order => 'created_at DESC', :per_page => @options.per_page)
    end

    if conn_id.present?
      @content_node = ContentNode.find_by_id(conn_id)
      set_title(@content_node.node.title,'review') if @content_node
    end

  
    render_paragraph :feature => :user_review_page_list
  end

  def submit
    @options = paragraph_options :submit

    if myself.id && session[:user_review_submitted]
      @review = UserReviewReview.find_by_id(session[:user_review_submitted])
      if @review
        @review.update_attributes(:end_user_id => myself.id)
        session[:user_review_submitted] = nil

        entry = UserProfileEntry.fetch_first_entry(myself)
        if entry && entry.content_model_entry
          entry.content_model_entry.attributes = @review.model.match_models(entry.content_model_entry)
          entry.content_model_entry.save
        end

        return redirect_paragraph @options.success_page_url
      end
    end


    if editor?
      node = ContentNode.find(:first)
    else
      conn_type,conn_id = page_connection

      node = ContentNode.find_by_id(conn_id)
    end
   
    @review = UserReviewReview.new({ :end_user_id => myself.id, 
                                     :user_review_type_id => @options.user_review_type_id,
                                     :container_node_id => node ? node.id : nil })
    require_js('prototype')

    if request.post? && params[:review]
      if @review.update_attributes(params[:review].slice(:title,:review_body,:rating,:model_data,:container_node_id))
        run_triggered_actions('action', @review, myself)
        
        if !myself.id
        # if we're not logged in, redirect to user login page, set session and review
          session[:user_review_submitted] = @review.id
          session[:lock_lockout] = controller.request.request_uri                 
          return redirect_paragraph @options.login_page_url
        else
          # if we are logged in, redirect to the thank you page
          # handle trigered actions
          return redirect_paragraph @options.success_page_url
        end
        

      end
    elsif myself.id
      entry = UserProfileEntry.fetch_first_entry(myself)
      if entry && entry.content_model_entry && @review.model
        @review.model.attributes = entry.content_model_entry.match_models(@review.model)
      end
    end
  
    render_paragraph :feature => :user_review_page_submit
  end

  def detail

    conn_type,@content_path = page_connection(:content_path)

    @options = paragraph_options :detail

    if !editor?
      conn_type,conn_id = page_connection
      @review = UserReviewReview.find_by_permalink(conn_id)

      raise SiteNodeEngine::MissingPageException.new( site_node, language ) if !@review && conn_id.present?

      if @review && @review.container_node
        set_title(h(@review.container_node.title.to_s + " - " + @review.title.to_s))
        set_title(h(@review.container_node.title.to_s + " - " + @review.title.to_s),'review')
      end
    else
      @review = UserReviewReview.first
    end


    render_paragraph :feature => :user_review_page_detail
  end

end
