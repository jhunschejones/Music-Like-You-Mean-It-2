class BlogsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_action :set_blog, only: [:show, :edit]
  skip_before_action :authenticate_admin_user, only: [:index, :show]

  def index
    if @current_user&.can_manage_blogs?
      @blogs = Blog.includes(:tags).with_rich_text_content.order({ published_at: :desc })
      return render :admin
    end

    @blogs =
      if params[:tag].is_a? Array
        Blog.joins(:tags)
          .where("tags.text IN (?)", params[:tag])
          .distinct
      elsif params[:tag]
        Blog.joins(:tags)
          .where("tags.text = ?", params[:tag])
          .distinct
      elsif params[:q]
        Blog.joins(:tags, :action_text_rich_text)
          .where("lower(action_text_rich_texts.body) LIKE ?", "%#{params[:q].strip.downcase}%")
          .or(
            Blog.joins(:tags, :action_text_rich_text)
                .where("lower(blogs.title) LIKE ?", "%#{params[:q].strip.downcase}%")
          )
          .distinct
      else
        Blog.includes(:tags)
      end
        .published
        .order({ published_at: :desc })
        .with_rich_text_content
        .paginate(page: params[:page] || 1, per_page: 10)

    if params[:q] && @blogs.present?
      flash.now[:success] = "#{pluralize(@blogs.size, "result")} matching '#{params[:q].strip.downcase}'"
    elsif params[:q]
      flash.now[:notice] = "No blogs matched the phrase '#{params[:q].strip.downcase}'"
    end
  end

  def show
    redirect_to blogs_path if @blog.is_draft? && !@current_user&.can_manage_blogs?
  end

  def new
    @blog = Blog.new
  end

  def edit
    @tag = Tag.new
  end

  def create
    ActiveRecord::Base.transaction do
      blog = Blog.create!(blogs_params.except(:blog_tags))
      if blogs_params[:blog_tags]
        blogs_params[:blog_tags].split(",").each do |tag_text|
          Tag.create!(blog_id: blog.id, text: tag_text)
        end
      end
    end

    redirect_to blogs_path
  end

  def update
    ActiveRecord::Base.transaction do
      @blog = Blog.find(params[:id])
      @blog.update!(blogs_params.except(:blog_tags))
      if params[:blog][:tag]
        params[:blog][:tag][:text].split(",").each do |tag_text|
          Tag.create(text: tag_text, blog_id: @blog.id)
        end
      end
    end

    redirect_to blog_path(@blog)
  end

  private

  def set_blog
    @blog =
      if params[:id].to_i.to_s == params[:id]
        Blog.includes(:tags).find(params[:id])
      else
        Blog.includes(:tags).where(named_url: params[:id]).first
      end

    raise ActiveRecord::RecordNotFound unless @blog
  end

  def blogs_params
    params.require(:blog).permit(:title, :embedded_video, :published_at, :content, :named_url, :is_draft, :blog_tags, tag_attributes: [:text, :blog_id])
  end
end
