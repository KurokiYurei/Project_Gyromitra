using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UI_Manager : MonoBehaviour
{
    [SerializeField]
    private GameObject m_Crosshair;

    [SerializeField]
    private Transform m_arrowSpawnPoint;

    private static Vector3 m_centerOfScreen = new Vector3(0.5f, 0.5f, 0f);

    private RaycastHit m_rayCastHit;

    private float m_rayLength = 100f;

    [SerializeField]
    private void Update()
    {

        Debug.DrawRay(m_arrowSpawnPoint.transform.position, m_arrowSpawnPoint.transform.forward * m_rayLength, Color.red);

        if (Physics.Raycast(m_arrowSpawnPoint.transform.position, m_arrowSpawnPoint.transform.TransformDirection(Vector3.forward), out m_rayCastHit, m_rayLength) && m_rayCastHit.transform.gameObject.tag == "Enemy")
        {

            ChangeColorCrosshair(Color.red);
            print("red");

        } else
        {
            ChangeColorCrosshair(Color.white);
            print("white");
        }
    }

    public void ChangeColorCrosshair(Color color)
    {

        Image[] l_imageList = this.GetComponentsInChildren<Image>();

        for (int i = 0; i < l_imageList.Length; i++)
        {
            l_imageList[i].color = color;
        }

    }
}
