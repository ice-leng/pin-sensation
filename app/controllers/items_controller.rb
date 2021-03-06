class ItemsController < ApplicationController
  #xoxb-66734971440-vDCyCHjPD9s5ofslVyjE2mUn
  before_action :authenticate_user!

  def create
    list = List.last || List.create!
    item = Item.create!(params_for_create.merge({ list: list, user: current_user }))

    ActionCable.server.broadcast 'items',
      action: 'create',
      template: render(partial: 'lists/list_item', locals: { item: item })
  end

  def destroy
    item = current_user.items.find(params_for_destroy)
    item.destroy!
    ActionCable.server.broadcast 'items',
      action: 'destroy',
      item: { id: item.id }
    head :ok
  end

  private

  def params_for_destroy
    params.require(:item).permit(:id).fetch(:id)
  end

  def params_for_create
    params.require(:item).permit(:content, :comment)
  end
end
