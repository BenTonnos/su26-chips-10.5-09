# frozen_string_literal: true

class MyNewsItemsController < ApplicationController
  before_action :require_login!

  before_action :set_representative, only: %i[new create edit update destroy]
  before_action :set_representatives_list
  before_action :set_news_item, only: %i[edit update destroy]

  def new
    @news_item = NewsItem.new
  end

  def search
    if params.dig(:news_item, :representative_id).present?
      @selected_representative = Representative.find(params[:news_item][:representative_id])
    end

    @issue = params.dig(:news_item, :issue)
  end

  def edit; end

  def create
    selected_index = params[:article_index]
    article = params.dig(:articles, selected_index) if selected_index.present?

    @news_item = if article.present?
                   NewsItem.new(
                     title: article[:title],
                     link: article[:link],
                     description: article[:description],
                     issue: params.dig(:news_item, :issue),
                     representative_id: params.dig(:news_item, :representative_id) || @representative&.id
                   )
                 else
                   NewsItem.new(news_item_params)
                 end

    if @news_item.save
      redirect_to representative_news_item_path(@news_item.representative, @news_item),
                  notice: 'News item was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @news_item.update(news_item_params)
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @news_item.destroy
    redirect_to representative_news_items_path(@representative),
                notice: 'News was successfully destroyed.'
  end

  private

  def set_representative
    @representative = Representative.find(
      params[:representative_id]
    )
  end

  def set_representatives_list
    @representatives_list = Representative.all.map { |r| [r.name, r.id] }
  end

  def set_news_item
    @news_item = NewsItem.find(params[:id])
  end

  def news_item_params
    params.require(:news_item).permit(:title, :issue, :description, :link, :representative_id)
  end
end
