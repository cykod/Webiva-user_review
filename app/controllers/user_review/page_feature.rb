class UserReview::PageFeature < ParagraphFeature


  include PageHelper

  feature :user_review_page_list, :default_feature => <<-FEATURE
    FEATURE

  def user_review_page_list_feature(data)
    webiva_feature(:user_review_page_list,data) do |c|
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
    Detail Feature Code...
  FEATURE

  def user_review_page_detail_feature(data)
    webiva_feature(:user_review_page_detail,data) do |c|
      # c.define_tag ...
    end
  end

end
