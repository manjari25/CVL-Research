using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Kinect;
using System.Drawing;
using System.Windows.Media.Imaging;
using System.Windows;

namespace kinectDepth
{
    class Program
    {
        static void Main(string[] args)
        {
            myKinect k1;
            k1 = new myKinect();
            k1.initialize();
            Console.ReadKey();
        }
    }

    public class myKinect
    {
        //variables
        public KinectSensor sensor = null;
        public DepthImagePixel[] depthPixels;
        public int[] depthinmm;
        public string filename = @"C:\Users\Manjari\Desktop\depthData.dat";

        public void initialize()
        {
            //Ennumerate Kinect sensors
            foreach (KinectSensor potentialSensor in KinectSensor.KinectSensors)
            {
                if (potentialSensor.Status == KinectStatus.Connected)
                {
                    this.sensor = potentialSensor;
                    Console.WriteLine("Sensor Initialized!");
                    break;
                }
            }
            if (this.sensor == null)
                Console.WriteLine("Kinect not connected. Check connection and retry.");
            else
            {
                //---Enable data streaming and start the kinect                
                this.sensor.DepthStream.Enable(DepthImageFormat.Resolution640x480Fps30);
                this.sensor.Start();
                //---allocate data for storage
                this.depthPixels = new DepthImagePixel[this.sensor.DepthStream.FramePixelDataLength];
                this.depthinmm = new int[this.sensor.DepthStream.FramePixelDataLength];
                //---register an event that fires when data is ready
                this.sensor.DepthFrameReady += this.SensorDepthFrameReady;         
            }
        }
       
        // Fire when new event triggered
        private void SensorDepthFrameReady(object sender, DepthImageFrameReadyEventArgs e)
        {
            Console.WriteLine("Call");
            using (DepthImageFrame depthFrame = e.OpenDepthImageFrame())
            {
                if (depthFrame != null)
                {
                    depthFrame.CopyDepthImagePixelDataTo(this.depthPixels);
                    for (int i = 0; i < 307200 ; i++)
                    {
                        depthinmm[i] = depthPixels[i].Depth;
                    }
                    //write to file
                    //System.IO.File.WriteAllBytes(filename, depthPixels);
                } 
            }  
        }        
    }
}
