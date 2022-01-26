class TagsController < ApplicationController
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    respond_to(&:js)
  end

  private

  def tag_params
    params.require(:tag).permit(:text, :blog_id)
  end
end
