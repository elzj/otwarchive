class TagWikisController < ApplicationController
  
  def show
    @wiki = TagWiki.find(params[:id])
    @tag = @wiki.tag
  end
  
  def edit
    @wiki = TagWiki.find(params[:id])
    @tag = @wiki.tag
  end
  
  def update
    @wiki = TagWiki.find(params[:id])
    @tag = @wiki.tag
    if @wiki.update_attributes(params[:tag_wiki])
      redirect_to @tag
    else
      render :edit
    end
  end
  
end