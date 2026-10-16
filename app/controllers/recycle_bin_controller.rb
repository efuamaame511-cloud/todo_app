class RecycleBinController < ApplicationController
  def index
    @entries = RecycleBin.all
  end

  def restore
    if RecycleBin.restore(params[:id])
      redirect_to recycle_bin_path, notice: "Item restored"
    else
      redirect_to recycle_bin_path, alert: "This item could not be restored"
    end
  end
end
