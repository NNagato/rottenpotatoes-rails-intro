class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    redirect = false
    logger.debug(session.inspect)
    
    if params[:sort]
      @sorted = params[:sort]
      session[:sort] = params[:sort]
    elsif session[:sort]
      @sorted = session[:sort]
      redirect = true
    else
      @sorted = nil
    end
    
    if params[:commit] == "Refresh" && params[:ratings].nil?
      @ratings = nil
      session[:ratings] = nil
    elsif params[:ratings]
      @ratings = params[:ratings]
      session[:ratings] = params[:ratings]
    elsif session[:ratings]
      @ratings = session[:ratings]
      redirect = true
    else
      @ratings = nil
    end
    
    if redirect
      flash.keep
      redirect_to movies_path(sort: @sorted, ratings: @ratings)
    end
    
    if @ratings && @sorted
      @movies = Movie.where(:rating => params[:ratings].keys).all.order(@sorted)
    elsif @ratings
      @movies = Movie.where(:rating => @ratings.keys)
    elsif @sorted
      @movies = Movie.all.order(@sorted)
    else 
      @movies = Movie.all
    end
    
    if !@ratings
      @ratings = Hash.new
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
