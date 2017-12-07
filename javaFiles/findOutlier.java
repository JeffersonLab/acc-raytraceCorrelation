import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

public class findOutlier {
	public static ArrayList<String> elementName = new ArrayList<String>();
	public static ArrayList<Double> M1 = new ArrayList<Double>();
	public static ArrayList<Double> M2 = new ArrayList<Double>();
	public static ArrayList<Double> M3 = new ArrayList<Double>();
	public static ArrayList<Double> M4 = new ArrayList<Double>();

	public static void setValues() {
		try {
			BufferedReader br = new BufferedReader(new FileReader("comparisons.fin"));
			String line;
			String[] values;
			// Write all strengths to the file
			while ((line = br.readLine()) != null) {
				values = line.split(" ");
				elementName.add(values[0]);
				M1.add(Double.parseDouble(values[1]));
				M2.add(Double.parseDouble(values[2]));
				M3.add(Double.parseDouble(values[3]));
				M4.add(Double.parseDouble(values[4]));
			}
			br.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static double findLargest(ArrayList<Double> M) {
		double largest = Integer.MIN_VALUE;
		for (double i : M) {
			if (i > largest) {
				largest = i;
			}
		}
		return largest;
	}

	public static void main(String[] args) {

		int M = Integer.parseInt(args[0]);
		setValues();

		switch (M) {
		case 1:
			M = 1;
			double largestM1 = findLargest(M1);
			int largestIndexM1 = M1.indexOf(largestM1);
			String largestElementM1 = elementName.get(largestIndexM1);
			System.out.println(largestElementM1 + " " + largestM1);
			break;
		case 2:
			M = 2;
			double largestM2 = findLargest(M2);
			int largestIndexM2 = M2.indexOf(largestM2);
			String largestElementM2 = elementName.get(largestIndexM2);
			System.out.println(largestElementM2 + " " + largestM2);
			break;
		case 3:
			M = 3;
			double largestM3 = findLargest(M3);
			int largestIndexM3 = M3.indexOf(largestM3);
			String largestElementM3 = elementName.get(largestIndexM3);
			System.out.println(largestElementM3 + " " + largestM3);
			break;
		case 4:
			M = 4;
			double largestM4 = findLargest(M4);
			int largestIndexM4 = M4.indexOf(largestM4);
			String largestElementM4 = elementName.get(largestIndexM4);
			System.out.println(largestElementM4 + " " + largestM4);
			break;
		}
	}
}
