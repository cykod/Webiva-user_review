class UserReview::PageController < ParagraphController

  editor_header 'User Review Paragraphs'
  
  editor_for :list, :name => "List User Review", :feature => :user_review_page_list, :inputs => [[ :content_node_id, 'Content Node', :content_node_id ]]
  editor_for :submit, :name => "Submit User Review", :feature => :user_review_page_submit, :inputs => [[ :content_node_id, 'Content Node', :content_node_id ]]

  editor_for :detail, :name => "User Review Detail", :feature => :user_review_page_detail, :inputs => [[ :content_node_id, 'Content Node', :content_node_id ]]


  class ListOptions < HashModel
    # Paragraph Options
    # attributes :success_page_id => nil

    options_form(
                 # fld(:success_page_id, :page_selector) # <attribute>, <form element>, <options>
                 )
  end

  class SubmitOptions < HashModel
    # Paragraph Options
    attributes :success_page_id => nil, :login_page_id => nil, :user_review_type_id => nil, :content_publication_id => nil

    page_options :login_page_id, :success_page_id 

    options_form(
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
  end

  class DetailOptions < HashModel
    # Paragraph Options
    # attributes :success_page_id => nil

    options_form(
                 # fld(:success_page_id, :page_selector) # <attribute>, <form element>, <options>
                 )
  end

end
