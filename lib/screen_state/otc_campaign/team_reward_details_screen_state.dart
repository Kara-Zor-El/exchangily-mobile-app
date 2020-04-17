import 'package:exchangilymobileapp/logger.dart';
import 'package:exchangilymobileapp/screen_state/base_state.dart';
import 'package:exchangilymobileapp/service_locator.dart';
import 'package:exchangilymobileapp/services/campaign_service.dart';
import 'package:exchangilymobileapp/models/campaign/team_reward.dart';

class TeamRewardDetailsScreenState extends BaseState {
  final log = getLogger('TeamRewardDetailsScreenState');
  CampaignService campaignService = locator<CampaignService>();
  List<CampaignTeamReward> campaignTeamRewardList = [];
  Map<String, dynamic> teamValueAndRewardWithToken;
// Init state
  void initState() {
    getTeamRewardDetails();
  }

  getTeamRewardDetails() async {
    setBusy(true);
    await campaignService
        .getTeamsRewardDetailsByToken(teamValueAndRewardWithToken['token'])
        .then((res) {
      campaignTeamRewardList = res;
      // log.w(c)
    });
    setBusy(false);
  }
}