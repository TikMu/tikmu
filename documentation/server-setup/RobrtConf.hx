import robrt.server.ServerConfig;

class RobrtConf {
	static var serverAddress = "new.maxikali.com";
	static var logUrl = 'https://$serverAddress:2000/logs/$$build_id.txt';
	static var branchUrl = 'https://$$base_branch.$serverAddress';
	static var prUrl = 'https://pr-$$pr_number.$serverAddress';

	static var ghBranchUrl = "https://github.com/$user/$repo/commits/$base_branch";
	static var ghPrUrl = "https://github.com/$user/$repo/pull/$pr_number";
	static var ghBranchCommitUrl = "https://github.com/$user/$repo/commit/$base_commit";
	static var ghPrCommitUrl = "https://github.com/$user/$repo/commit/$pr_commit";

	static var githubPayload:CustomPayload = {
		pull_requests : [
		{ events : [EStarted], payload : { state : "pending", description : "Received" } },

		{ events : [EOpeningRepo], payload : { state : "pending", description : "Cloning and attempting to merge" } },
		{ events : [ERepositoryError], payload : { state : "error", description : "Error opening repository (build id is $build_id)" } },
		{ events : [EFailedMerge], payload : { state : "failure", description : "This branch has conflicts that must be resolved" } },

		{ events : [EPreparing], payload : { state : "pending", description : "Preparing a docker container" } },
		{ events : [EInvalidRepoConf], payload : { state : "failure", description : "Missing or invalid .robrt.json" } },
		{ events : [ENoRepoPrepare], payload : { state : "failure", description : "Nothing to do (no 'prepare' in .robrt.json)" } },
		{ events : [EPrepareError], payload : { state : "error", description : "Error preparing container (build id is $build_id)" } },

		{ events : [EBuilding], payload : { state : "pending", description : "Building" } },
		{ events : [ENoBuild], payload : { state : "error", description : "Nothing to build (build id is $build_id)" } },
		{ events : [ENoRepoBuild], payload : { state : "failure", description : "Nothing to build (no 'build' in .robrt.json or no commands to run)" } },
		{ events : [EBuildError], payload : { state : "error", description : "Error running build (build id is $build_id)" } },
		{ events : [EBuildFailure], payload : { state : "failure", description : "Build error", target_url : logUrl } },

		{ events : [EExporting], payload : { state : "pending", description : "Exporting" } },
		{ events : [ENoExport], payload : { state : "error", description : "Nothing to export (build id is $build_id)" } },
		{ events : [EExportError], payload : { state : "error", description : "Error exporting (build id is $build_id)" } },

		{ events : [EDone], payload : { state : "success", description : "Build id $build_id successfull.  Output generated...", target_url : prUrl } },
		],
	}

	static var slackPayload:CustomPayload = {
		branch_builds : [
		{
			events : [EBuildFailure],
			payload : {
				fallback : "Sorry, failed to build commit $base_commit_short", "color" : "#D00000",
				fields : [
				{
					title : "Error", "short" : false,
					value : "I'm sorry, but branch '$base_branch' has failed to build.  This can very well be my fault, but you can check the log and see if there's something you can do"
				},
				{
					title : "Additional information", short : false,
					value : '(<$ghBranchUrl|view branch>, <$ghBranchCommitUrl|view commit>, <$logUrl|view log>)',
				}
				]
			}
		},
		{
			events : [EExportSuccess],
			payload : {
				fallback : "Your updated '$base_branch' branch is available at commit $base_commit_short",
				color : "#00D000",
				fields : [
				{
					title : "Rendered branch '$base_branch'", short : false,
					value : '<$branchUrl>',
				},
				{
					title : "Additional information", short : false,
					value : '(<$ghBranchUrl|view branch>, <$ghBranchCommitUrl|view commit>, <$logUrl|view log>)',
				}
				]
			}
		},
		{
			events : [ EInvalidRepoConf, ERepositoryError, ENoRepoPrepare, EPrepareError, ENoBuild, ENoRepoBuild, EBuildError, ENoExport, EExportError ],
			payload : {
				fallback : "Sorry, failed miserably with build $build_id", "color" : "#D0D0D0",
				fields : [ {
					title : "Bip... Bip... Failure", short : false,
					value : "I'm very sorry, but I appear to be severely malfunctioning!  My overlord Jonas has been alerted and will fix me as soon as possible.  The build id was $build_id."
				} ]
			}
		}
		],
		pull_requests : [
		{
			events : [EFailedMerge],
			payload : {
				fallback : "Sorry, pull request #$pr_number has conflicts that must be resolved", "color" : "#D00000",
				fields : [
				{
					title : "Error", "short" : false,
					value : "I'm sorry, but pull request #$pr_number has conflicts that must be resolved before I can attempt to build it."
				},
				{
					title : "Additional information", short : false,
					value : '(<$ghPrUrl|view pull request>)',
				}
				]
			}
		},
		{
			events : [EBuildFailure],
			payload : {
				fallback : "Sorry, failed to build pull request $pr_number", "color" : "#D00000",
				fields : [
				{
					title : "Error", "short" : false,
					value : "I'm sorry, but pull request #$pr_number has failed to build.  This can very well be my fault, but you can check the log and see if there's something you can do"
				},
				{
					title : "Additional information", short : false,
					value : '(<$ghPrUrl|view pull request>, <$ghPrCommitUrl|view commit>, <$logUrl|view log>)',
				}
				]
			}
		},
		{
			events : [EExportSuccess],
			payload : {
				fallback : "Your updated pull request #$pr_number is available at commit $pr_commit_short",
				color : "#00D000",
				fields : [
				{
					title : "Rendered pull request #$pr_number", short : false,
					value : '<$prUrl>',
				},
				{
					title : "Additional information", short : false,
					value : '(<$ghPrUrl|view pull request>, <$ghPrCommitUrl|view commit>, <$logUrl|view log>)',
				}
				]
			}
		},
		{
			events : [ EInvalidRepoConf, ERepositoryError, ENoRepoPrepare, EPrepareError, ENoBuild, ENoRepoBuild, EBuildError, ENoExport, EExportError ],
			payload : {
				fallback : "Sorry, failed miserably with build $build_id", "color" : "#D0D0D0",
				fields : [ {
					title : "Bip... Bip... Failure", short : false,
					value : "I'm very sorry, but I appear to be severely malfunctioning!  My overlord Jonas has been alerted and will fix me as soon as possible.  The build id was $build_id."
				} ]
			}
		}
		]
	};

	static var conf:ServerConfig = {
		repositories : [
		{
			full_name : "jonasmalacofilho/tikmu",
			hook_secret : "not much of a secret, but will have to make due for now",
			oauth2_token : "f0fdb07653673e9cad7e8838a3788103a96d1740",
			build_options : {
				directory : "/var/robrt/builds/jonasmalacofilho/tikmu",
			},
			export_options : {
				destination : {
					branches : "/var/www/tikmu/heads/$base_branch",
					pull_requests : "/var/www/tikmu/heads/pr-$pr_number",
					build_log : "/var/www/robrt/logs/$build_id.txt"
				},
			},
			notification_targets : [
			{
				name : "slack", type : Slack, customPayload : slackPayload,
				url : "https://hooks.slack.com/services/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",
			},
			{
				name : "github", type : GitHub, customPayload : githubPayload
			}
			]
		}
		]
	}

	static function main()
	{
		try {
			var json = haxe.Json.stringify(conf, "  ");
			Sys.println(json);
		} catch (e:Dynamic) {
			Sys.stderr().writeString('ERROR: $e\n');
			Sys.exit(1);
		}
	}
}

