using Azure.Messaging.EventHubs;
using Lib01.Sql;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Customer.EventHandler
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
        public async Task NewOrder([EventHubTrigger(eventHubName: "neworder", Connection = "EventHubConsumer1", ConsumerGroup = "ch.demo.customer.eventhandler")] EventData message)
        {
            DateTime timeNow = TimeZoneInfo.ConvertTime(DateTime.Now, TimeZoneInfo.FindSystemTimeZoneById("CET"));

            await SqlCommanRunner.RunAsync(_sqlConnetion,
                $"INSERT INTO dbo.[CustomerOrder] ([Number],[ByApp],[ByCluster],[At]) VALUES ('{message.MessageId}','Customer.EH','{_appConfigLabel}','{timeNow.ToString("MM/dd/yyyy HH:mm:ss.fff tt")}')");
        }

        public async Task NewInvoice([EventHubTrigger(eventHubName: "newinvoice", Connection = "EventHubConsumer2", ConsumerGroup = "ch.demo.customer.eventhandler")] EventData message)
        {
            DateTime timeNow = TimeZoneInfo.ConvertTime(DateTime.Now, TimeZoneInfo.FindSystemTimeZoneById("CET"));

            await SqlCommanRunner.RunAsync(_sqlConnetion,
                $"INSERT INTO dbo.[CustomerInvoice] ([Number],[ByApp],[ByCluster],[At]) VALUES ('{message.MessageId}','Customer.EH','{_appConfigLabel}','{timeNow.ToString("MM/dd/yyyy HH:mm:ss.fff tt")}')");
        }
    }
}
