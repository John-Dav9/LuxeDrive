class SuperAdmin::ContractSettingsController < SuperAdmin::BaseController
  def edit
    @contract = ContractSetting.current
    render "super_admin/contract_settings_edit"
  end

  def update
    @contract = ContractSetting.current
    if @contract.update(contract_params.merge(updated_by: current_user))
      redirect_to edit_super_admin_contract_setting_path, notice: "Contrat mis à jour."
    else
      render "super_admin/contract_settings_edit", status: :unprocessable_entity
    end
  end

  private

  def contract_params
    params.require(:contract_setting).permit(
      :company_name,
      :company_address,
      :company_vat,
      :company_email,
      :contract_version,
      :jurisdiction
    )
  end
end
