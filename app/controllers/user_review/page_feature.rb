class UserReview::PageFeature < ParagraphFeature


  include PageHelper

  feature :user_review_page_list, :default_feature => <<-FEATURE
  <ol>
  <cms:review>
  <li>
      <h2><cms:detail_link><cms:title/></cms:detail_link></h2>
      <cms:rating/>
      <cms:submitted_by/>
      <cms:review_body/>
      <cms:submitted_at/>
      <cms:publication>
         
      </cms:publication>
  </li>
  </cms:review>
  </ol>
    FEATURE

  def user_review_page_list_feature(data)
    webiva_feature(:user_review_page_list,data) do |c|
      c.loop_tag('review') { |t| data[:reviews] }
      c.link_tag('review:detail') do |t| 
        if data[:options].detail_page_node 
          data[:options].detail_page_node.link(data[:content_path],t.locals.review.permalink) 
        else
          t.locals.review.content_node.link
        end
      end
      c.pagelist_tag('pages') { |t| data[:pages] }
      add_review_tags(c,data)
    end
  end

  feature :user_review_page_submit, :default_feature => <<-FEATURE
  <cms:review>
  <ol>
    <li><label>Rating:</label><cms:rating/></li>
    <li><label>Title:</label><cms:title/></li>
    <li><label>Review:</label><cms:review_body/></li>

    <cms:publication>
    <cms:field>
      <cms:error><li class='error'><cms:value/></li></cms:error>
      <li><cms:label/><cms:control/></li>
    </cms:field>
    </cms:publication>
  </ol>
  <cms:submit/>
  </cms:review>

  FEATURE

  def user_review_page_submit_feature(data)
    webiva_custom_feature(:user_review_page_submit,data) do |c|
      c.form_for_tag('review','review') { |t| data[:review] }
      c.form_error_tag('review:errors') { |t| [ data[:review], data[:review].model ].compact }
      c.field_tag('review:container_node_id', :control => 'select') do |t| 
         [['--Select--',nil ]] + ContentNode.find(:all,
                          :conditions => { 
                              :content_type_id => data[:options].content_type_id 
                            },:include => :node).map { |n| [ n.title, n.id ] }.sort { |a,b| a[0].to_s.downcase <=> b[0].to_s.downcase } 
      end
      c.field_tag('review:rating', :control => 'rating_field')
      c.field_tag('review:title')
      c.field_tag('review:review_body',:control => 'text_area')

      if data[:options].content_publication
        c.define_fields_for_tag('review:publication','review[model_data]') { |t| data[:review].model }
        c.publication_field_tags('review:publication',data[:options].content_publication)
      else
        c.expansion_tag('review:publication') { |t| false }
      end
      c.submit_tag('review:submit')
    end
  end

  feature :user_review_page_detail, :default_feature => <<-FEATURE
  <cms:review>
      <h1><cms:title/></h1>
      <cms:rating/>
      <cms:submitted_by/>
      <cms:review_body/>
      <cms:submitted_at/>
      <cms:publication>
         
      </cms:publication>
  </cms:review>
  <cms:return_link>Back to List</cms:return_link>
  FEATURE

  def user_review_page_detail_feature(data)
    webiva_feature(:user_review_page_detail,data) do |c|
      c.expansion_tag('review') { |t| t.locals.review = data[:review] }
      add_review_tags(c,data)
      c.link_tag('return') { |t| data[:options].list_page_node.link(data[:content_path]) if data[:options].list_page_node }
    end
  end
  
  def add_review_tags(c,data)
    c.attribute_tags('review',[ 'title','permalink' ]) { |t| t.locals.review }

    c.datetime_tag('review:submitted_at') { |t| t.locals.review.created_at }
    c.h_tag('review:review_body','value',:format => :simple) { |t| t.locals.review.review_body }

    c.value_tag('review:rating') { |t| t.locals.review.rating * (t.attr['multiplier'] || 1).to_i }

    c.h_tag('review:submitted_by') { |t| t.locals.review.end_user.username if t.locals.review.end_user }

    c.h_tag('review:subject') { |t| t.locals.review.container_node.title if t.locals.review.container_node}

    c.link_tag('review:detail') do |t| 
      t.locals.review.content_node.link
    end

    c.expansion_tag('review:publication') { |t| t.locals.entry = t.locals.review.model }

    if data[:options].user_review_type && cm = data[:options].user_review_type.content_model
      c.define_content_model_value_tags('review:publication',cm)
    end

  end

end
