class UserReview::PageController < ParagraphController

  editor_header 'User Review Paragraphs'
  
  editor_for :list, :name => "List User Review", :feature => :user_review_page_list, :inputs => { :input =>  [[ :content_node_id, 'Content Node', :content_node_id ]], :path =>  [[ :permalink, 'Permalink', :path ]], :content_path => [[ :permalink, "Content Path", :path ]] }
  editor_for :submit, :name => "Submit User Review", :feature => :user_review_page_submit, :inputs => [[ :content_node_id, 'Content Node', :content_node_id ], [ :content_node_path, 'Content Node Path', :path ]], :triggers => [['New Review Submitted','action']]
  editor_for :detail, :name => "User Review Detail", :feature => :user_review_page_detail, :inputs => { :input => [[ :permalink, 'Permalink', :path ]],  :content_path => [[ :permalink, "Content Path", :path ]] }



  class ListOptions < HashModel
    # Paragraph Options
    # attributes :success_page_id => nil
    attributes :detail_page_id => nil, :user_review_type_id => nil, :per_page => 10

    page_options :detail_page_id
    integer_options :per_page

    options_form(
                fld(:user_review_type_id, :select, :options => Proc.new { UserReviewType.select_options_with_nil } ),
                fld(:detail_page_id, :page_selector),
                fld(:per_page, :text_field)
                 )

    def user_review_type
      if self.user_review_type_id
        @user_review_type ||= UserReviewType.find_by_id(self.user_review_type_id)
      else
        nil
      end
    end
    

  end

  class SubmitOptions < HashModel
    # Paragraph Options
    attributes :success_page_id => nil, :login_page_id => nil, :user_review_type_id => nil, :content_publication_id => nil, :content_type_id => nil

    page_options :login_page_id, :success_page_id 

    options_form(
                fld(:content_type_id, :select, :options => Proc.new { ContentType.select_options_with_nil }),
                fld(:user_review_type_id, :select, :options => Proc.new { UserReviewType.select_options_with_nil } ),
                 fld(:success_page_id, :page_selector),
                 fld(:content_publication_id, :select, :options => :content_publication_options),
                 fld(:login_page_id, :page_selector)
                 )

    def user_review_type
      if self.user_review_type_id
        @user_review_type ||= UserReviewType.find_by_id(self.user_review_type_id)
      else
        nil
      end
    end
    
    def content_publication
      if self.content_publication_id
        @content_publication ||= ContentPublication.find_by_id(self.content_publication_id)
      else
        nil
      end
    end


    def content_publication_options
      if self.user_review_type
        [[ '--Select Publication--',nil]] + self.user_review_type.content_model.content_publications.select { |p| p.form? }.map { |p| [ p.name, p.id ]}
      else
        [['No Publications available',nil]]
      end

    end

    def options_partial
      "/application/triggered_options_partial"
    end

  end

  class DetailOptions < HashModel
    attributes :user_review_type_id => nil, :list_page_id => nil

    page_options :list_page_id

    options_form(
                fld(:user_review_type_id, :select, :options => Proc.new { UserReviewType.select_options_with_nil } ), 
                fld(:list_page_id, :page_selector)

                 )

    def user_review_type
      if self.user_review_type_id
        @user_review_type ||= UserReviewType.find_by_id(self.user_review_type_id)
      else
        nil
      end
    end

  end

end
