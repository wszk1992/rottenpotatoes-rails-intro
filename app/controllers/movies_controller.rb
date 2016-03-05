class MoviesController < ApplicationController
  helper_method :includeRatings?
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def includeRatings?(rating)
    if params[:ratings]
      params[:ratings].include?(rating)
    elsif session[:cur_ratings]
      session[:cur_ratings].include?(rating) 
    else 
      true 
    end
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratingValues
    if params[:ratings]
      session[:cur_ratings] = params[:ratings]
      @movies = Movie.where(rating: session[:cur_ratings].keys)
    elsif session[:cur_ratings]
      @movies = Movie.where(rating: session[:cur_ratings].keys)
    else
      @movies = Movie.all
      session[:cur_ratings] = Hash[@all_ratings.zip([1,1,1,1])]
    end
    if !params[:ratings]
      flash.keep
      if !session[:cur_ratings]
        redirect_to movies_path
      else
        redirect_to movies_path(:ratings => session[:cur_ratings])
      end
    end
    case params[:sort]
    when 'title'
      session[:cur_sort] = params[:sort]
      @movies = @movies.order(session[:cur_sort])
      @title_hilite = 'hilite'
    when 'release_date'
      session[:cur_sort] = params[:sort]
      @movies = @movies.order(session[:cur_sort])
      @date_hilite = 'hilite'
    else
        case session[:cur_sort]
        when 'title'
          @movies = @movies.order(session[:cur_sort])
          @title_hilite = 'hilite'
        when 'release_date'
          @movies = @movies.order(session[:cur_sort])
          @date_hilite = 'hilite'
        else
          @movies = @movies.all
        end
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
