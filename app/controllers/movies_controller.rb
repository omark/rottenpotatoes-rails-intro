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
    # Determine whether sorting by title or release date or not at all
    sort_by = params[:sort_by] || session[:sort_by]
    case sort_by
    when 'title'
      ordering, @title_hdr_class = {:title => :asc}, 'hilite'
    when 'release_date'
      ordering, @release_date_hdr_class = {:release_date => :asc}, 'hilite'
    end
    # Determine whether filtering and how
    @all_ratings = Movie.all_ratings
    @filter_ratings = params[:ratings] || session[:ratings] || {}
    # If no filter specified specify all (create hash similar to what is passed in)
    if @filter_ratings == {}
      @filter_ratings = Hash[@all_ratings.map {|rating| [rating, 1]}]
    end
    # If either sorting or filtering spec has changed save both and redirect
    if params[:sort_by] != session[:sort_by] or params[:ratings] != session[:ratings]
      session[:sort_by] = sort_by
      session[:ratings] = @filter_ratings
      redirect_to :sort_by => sort_by, :ratings => @filter_ratings and return
    end
    # Filter movies by rating and sort
    @movies = Movie.where(rating: @filter_ratings.keys).order(ordering)
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
