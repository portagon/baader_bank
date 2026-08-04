# frozen_string_literal: true

module BaaderBank
  class Client
    # Asset-Managers API. `zip_file_download_url` is the endpoint that
    # replaces the legacy form-POST-based CSV/PDF statement downloads
    # (`base_downloader.rb`) - it returns a download URL, not the file
    # itself, so callers need a follow-up plain GET on that URL.
    #
    # FILE_TYPES is Baader's enum, not yet mapped to the legacy record types
    # (RKK/WDP/WUM/AKS/AEA/ZIPCSV/ZIPPDF*) this gem's consumers currently
    # rely on - pending Baader's answer to that open question.
    module AssetManagers
      FILE_TYPES = %w[PDF1 PDF2 PDF3 PDFN CSV1 CSV2 CSV3 CSVN CSVK].freeze

      def asset_manager(asset_manager_id)
        get("v2/asset-manager/#{asset_manager_id}")
      end

      def asset_manager_balance(asset_manager_id)
        get("v2/asset-manager/#{asset_manager_id}/balance")
      end

      def asset_manager_closed_info(asset_manager_id)
        get("v2/asset-manager/#{asset_manager_id}/closed-info")
      end

      def asset_manager_intraday_payments(asset_manager_id)
        get("v2/asset-manager/#{asset_manager_id}/intraday-payments")
      end

      def asset_manager_intraday_account_openings(asset_manager_id)
        get("v2/asset-manager/#{asset_manager_id}/intraday-account-openings")
      end

      # No v2 replacement is documented for these - the v1 paths are marked
      # deprecated with no alternative listed. Kept for parity with the
      # current (SFTP-era) interday reconciliation flow; confirm with
      # Baader before relying on them long-term.
      def asset_manager_interday_payments(asset_manager_id)
        get("asset-manager/#{asset_manager_id}/interday-payments")
      end

      def asset_manager_interday_account_openings(asset_manager_id)
        get("asset-manager/#{asset_manager_id}/interday-account-openings")
      end

      # Returns a download URL for the requested file type/date. `file_type`
      # must be one of FILE_TYPES. `file_date` defaults to the current day.
      def zip_file_download_url(file_type, file_date: nil)
        params = file_date ? { "file-date" => file_date } : {}
        get("v2/asset-manager/files/#{file_type}", params)
      end
    end

    include AssetManagers
  end
end
