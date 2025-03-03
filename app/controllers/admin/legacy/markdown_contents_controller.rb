class Admin::Legacy::MarkdownContentsController < Admin::Legacy::AdminController
  load_resource
  respond_to :html

  def create
    @markdown_content.attributes = markdown_content_params
    @markdown_content.save!
    redirect_to admin_legacy_markdown_content_path(@markdown_content)
  end

  def update
    @markdown_content.update(markdown_content_params)
    redirect_to admin_legacy_markdown_content_path(@markdown_content)
  end

  def index; end
  def show; end
  def edit; end

  def markdown_content_params
    params.require(:markdown_content).permit(:name, :slug, :markdown)
  end
end
