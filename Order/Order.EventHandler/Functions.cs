using Azure.Messaging.EventHubs;
using Lib01.Sql;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Order.EventHandler
{
    public class Functions
    {
        private readonly string _sqlConnetion;
        private readonly string _appConfigLabel;

        public Functions(IConfiguration config)
        {
            _sqlConnetion = config.GetValue<string>("SqlDBConnection");
            _appConfigLabel = config.GetValue<string>("AppConfigLabel");
        }
        public async Task NewOrder([EventHubTrigger(eventHubName: "neworder", Connection = "EventHubConsumer1", ConsumerGroup = "ch.demo.order.eventhandler")] EventData message)
        {
            DateTime timeNow = TimeZoneInfo.ConvertTime(DateTime.Now, TimeZoneInfo.FindSystemTimeZoneById("CET")); // Linux CET Win W. Europe Standard Time

            await SqlCommanRunner.RunAsync(_sqlConnetion,
                $"UPDATE dbo.[Order] SET [Status] = 'Created', [CreatedByApp] = 'Order.EH', [CreatedByCluster] = '{_appConfigLabel}', [CreatedAt] = '{timeNow.ToString("MM/dd/yyyy HH:mm:ss.fff tt")}' WHERE [Number] = '{message.MessageId}'");
        }
    }
}
