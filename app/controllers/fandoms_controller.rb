class FandomsController < ApplicationController
  before_filter :load_collection

  def index
    if @collection
      @media = Media.canonical.by_name - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME)]
      @page_subtitle = @collection.title
      if params[:medium_id]
        @medium = Media.find_by_name(params[:medium_id])
        @fandoms = @medium.fandoms.canonical if @medium
      end
      @fandoms = (@fandoms || Fandom).where("filter_taggings.inherited = 0").
                  for_collections_with_count([@collection] + @collection.children)
    elsif params[:medium_id]
      if @medium = Media.find_by_name(params[:medium_id])
         @page_subtitle = @medium.name
        if @medium == Media.uncategorized
          @fandoms = @medium.fandoms.in_use.by_name
        else
          @fandoms = @medium.fandoms.canonical.by_name.with_count
        end      
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find media category named '#{params[:medium_id]}'"
      end
    else
      redirect_to media_path(:notice => "Please choose a media category to start browsing fandoms.")
      return
    end
    @fandoms_by_letter = @fandoms.group_by {|f| f.name[0].upcase}
  end
  
  def show
    @fandom = Fandom.find_by_name(params[:id])
    if @fandom.nil?
      setflash; flash[:error] = ts("Could not find fandom named %{fandom_name}", :fandom_name => params[:id])
      redirect_to media_path and return
    end

    @wiki = @fandom.tag_wiki || @fandom.create_tag_wiki
    @fandom_tag_types = FandomTag::VALID_TYPES
    @fandom_tags = @fandom.fandom_tags.order(:name).group_by{ |tag| tag.type.to_s }
    @media = @fandom.medias.by_name
    @languages = @fandom.languages.order(:short).group('languages.id')
    @characters = @fandom.characters.canonical.public_top(5)
    @relationships = @fandom.relationships.canonical.public_top(5)
    @pseuds = @fandom.pseuds.group('pseuds.id').order('works.created_at DESC').limit(5)
    @collections = @fandom.approved_collections.order('collections.created_at DESC').limit(5)
  end
  
  def edit
    @fandom = Fandom.find_by_name(params[:id])
  end
  
  def update
    @fandom = Fandom.find_by_name(params[:id])
    @fandom.attributes = params[:fandom]
    redirect_to @fandom
  end
  
  def unassigned
    join_string = "LEFT JOIN wrangling_assignments 
                  ON (wrangling_assignments.fandom_id = tags.id) 
                  LEFT JOIN users 
                  ON (users.id = wrangling_assignments.user_id)"
    conditions = "canonical = 1 AND users.id IS NULL"
    unless params[:media_id].blank?
      @media = Media.find_by_name(params[:media_id])
      if @media
        join_string <<  " INNER JOIN common_taggings 
                        ON (tags.id = common_taggings.common_tag_id)" 
        conditions  << " AND common_taggings.filterable_id = #{@media.id} 
                        AND common_taggings.filterable_type = 'Tag'"
      end
    end
    @fandoms = Fandom.joins(join_string).
                      where(conditions).
                      order(params[:sort] == 'count' ? "count DESC" : "name ASC").
                      with_count.
                      paginate(:page => params[:page], :per_page => 250)  
  end
end
