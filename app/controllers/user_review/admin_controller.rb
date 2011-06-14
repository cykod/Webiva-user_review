
class UserReview::AdminController < ModuleController

  component_info 'UserReview', :description => 'User Review support', 
                              :access => :public
                              
  # Register a handler feature
  register_permission_category :user_review, "UserReview" ,"Permissions related to User Review"
  
  register_permissions :user_review, [ [ :manage, 'Manage User Review', 'Manage User Review' ],
                                  [ :config, 'Configure User Review', 'Configure User Review' ]
                                  ]
  cms_admin_paths "options",
     "User Review Types" => { :action => 'options' },
     "Options" => { :controller => '/options' },
     "Modules" => { :controller => '/modules' }

  permit 'user_review_config'

  content_model :user_review_review

  register_handler :site_feature, :blog_entry_list, "UserReviewFeature"
  register_handler :site_feature, :blog_entry_detail, "UserReviewFeature"

  public 

  def self.get_user_review_review_info
    [{ :name => 'User Reviews', :url => { :controller => '/user_review/manage', :action => 'index' }, :permission => :user_review_manage }
     ]
  end


  active_table :user_review_types_table, UserReviewType, [
      :check,:name
  ]

  def display_user_review_types_table(display=true)

    @tbl = user_review_types_table_generate(params,:order => 'created_at DESC')

    render :partial => 'user_review_types_table' if display
  end


  def options
    cms_page_path ['Options','Modules'],"User Review Types"
   
    active_table_action(:user_review_types) do |act,tids|
      UserReviewType.find(tids).map(&:destroy) if act == 'delete'
    end
    
    display_user_review_types_table(false)
  end

  def edit
    @user_review_type = UserReviewType.find_by_id(params[:path][0]) || UserReviewType.new

    cms_page_path ['Options','Modules', 'User Review Types'], @user_review_type.new_record? ? 'Create User Review Type' : [ 'Edit %s',nil,@user_review_type.name ] 

    if request.post? && params[:user_review_type]
      if @user_review_type.update_attributes(params[:user_review_type])
        redirect_to :action => 'options'
      end
    end
  end

 
  def set_options
    cms_page_path ['Options','Modules'],"User Review Options"
    
    @options = self.class.module_options(params[:options])
    
    if request.post? && @options.valid?
      Configuration.set_config_model(@options)
      flash[:notice] = "Updated User Review module options".t 
      redirect_to :controller => '/modules'
      return
    end    
  
  end
  
  def self.module_options(vals=nil)
    Configuration.get_config_model(Options,vals)
  end
  
  class Options < HashModel
   # Options attributes 
   # attributes :attribute_name => value
  
  end

end
