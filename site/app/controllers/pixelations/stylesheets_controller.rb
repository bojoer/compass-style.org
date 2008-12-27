require 'application'
require 'timeout'

class Pixelations::StylesheetsController < ApplicationController
  SASS_ENGINE_OPTS = {
    :load_paths => Compass::Frameworks::ALL.map{|f| f.stylesheets_directory} + ["#{RAILS_ROOT}/app/stylesheets/pixelations"]
  }
  layout false

  def new
    @stylesheet = Stylesheet.new
  end

  def create
    @stylesheet = Stylesheet.create(params[:stylesheet])
    redirect_to pixelations_path(:stylesheet => @stylesheet.url_name)
  end

  def show
    @stylesheet = Stylesheet.find_by_url(params[:id])
    if @stylesheet
      respond_to do |wants|
        wants.sass { render :text => @stylesheet.sass }
        wants.css  { render :text => @stylesheet.css  }
      end
    else
      render_error_status(404)
    end
  end

  def compile
    @sass = params[:sass]
    begin
      Timeout::timeout(1) {
        @css = Sass::Engine.new(@sass, SASS_ENGINE_OPTS).render
      }
      render :text => @css, :layout => false
    rescue Sass::SyntaxError => e
      render :text => "Syntax Error: #{e.message}", :status => 400, :layout => false
    rescue Timeout::Error
      render :text => "Sorry: Sass Compilation is taking too long.", :status => 400, :layout => false
    end
  end

end