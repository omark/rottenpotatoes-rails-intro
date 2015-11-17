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
    # All available ratings
    @all_ratings = Movie.select(:rating).map(&:rating).uniq
    # All available movies
    @movies = Movie.all
    # Will have to redirect if update from session
    redirect_required = false

    if params[:ratings]
      # If specified get ratings and save to session
      logger.debug "Ratings from params"
      ratings = params[:ratings]
    elsif session[:ratings]
      # If retrieved from session redirect
      logger.debug "Ratings from session"
      ratings = session[:ratings]
      redirect_required = true
    else
      # If neither
      # Create new hash, save to session, and redirect
      logger.debug "Ratings from scratch"
      ratings = Hash[@all_ratings.map {|r| [r, 1]}]
      redirect_required = true
    end

    # Update page to render ratings selection correctly
    @filter_ratings = ratings.keys
    if @filter_ratings.empty?
      @filter_ratings = @all_ratings
    end

    if params[:sort_by]
      # If specified get value
      logger.debug "Sorting from params"
      sort_by = params[:sort_by]
    elsif flash[:sort_by]
      # If retrieved from flash
      logger.debug "Sorting from flash"
      sort_by = flash[:sort_by]
    else
      # If neither set to None, save to session, and redirect
      logger.debug "Sorting from scratch"
      sort_by = 'None'
    end

    if redirect_required == true
      flash[:sort_by] = sort_by
      logger.debug "Redirecting"
      redirect_to movies_path(:ratings => ratings)
    end

    session[:ratings] = ratings

    # filter based on filter ratings
    @movies = @movies.where(rating: @filter_ratings)

    # Sort if required
    logger.debug "Sorting"
    if sort_by != 'None'
      @movies = @movies.order(sort_by)
    end

    # Hilite to match
    if 'title' == sort_by
      @title_hdr_class = 'hilite' 
    elsif 'release_date' == sort_by
      @release_date_hdr_class = 'hilite'
    else
      @title_hdr_class = 'nohilite'
      @release_date_hdr_class = 'nohilite'
    end

    logger.debug "Filter ratings:"
    @filter_ratings.each do |fb| logger.debug "#{fb}" end
    logger.debug "Sort by: #{sort_by}"
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
