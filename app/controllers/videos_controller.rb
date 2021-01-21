class VideosController < ApplicationController
  before_action :require_video, only: [:show]

  def index
    if params[:query]
      data = VideoWrapper.search(params[:query])
    else
      data = Video.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @video.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
      )
  end

  def create
    @video = Video.new(title: params[:title],
                       overview: params[:overview],
                       release_date: params[:release_date],
                       image_url: params[:image_url],
                       external_id: params[:external_id])
    if Video.find_by(params[:external_id])
      render status: :bad_request, json: { error: { external_api: ["This video is already in your library"] } }
    else
      @video.save
      render status: :ok
    end
  end

  private

  def video_params
    params.permit(:title, :overview, :release_date, :image_url, :external_id)
  end

  def require_video
    @video = Video.find_by(title: params[:title])
    unless @video
      render status: :not_found, json: { errors: { title: ["No video with title #{params["title"]}"] } }
    end
  end
end
