using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Credits : MonoBehaviour
{

    [SerializeField]
    private Animation m_animation;

    [SerializeField]
    private GameObject m_background;

    [SerializeField]
    private GameObject m_frame;

    private string m_titleAnim;
    private string m_developersAnim;
    private string m_tanksAnim;

    private void Awake()
    {
        m_titleAnim = "TheEndText";
        m_developersAnim = "ShowDeveloper";
        m_tanksAnim = "ThanksForPlaying";

        m_background = gameObject.transform.Find("Background").gameObject;
        m_frame = gameObject.transform.Find("Frame").gameObject;

        m_background.SetActive(false);
        m_frame.SetActive(false);

    }

    public void StartCinematics(GameObject l_player)
    {
        m_background.gameObject.SetActive(true);
        m_frame.gameObject.SetActive(true);

        l_player.GetComponent<CharacterController>().enabled = false;
        l_player.GetComponent<CharacterControllerScript>().enabled = false;
        l_player.GetComponent<WeaponController>().enabled = false;
        l_player.GetComponent<Animator>().enabled = false;

        m_animation.PlayQueued(m_titleAnim, QueueMode.CompleteOthers);
        m_animation.PlayQueued(m_developersAnim, QueueMode.CompleteOthers);
        m_animation.PlayQueued(m_tanksAnim, QueueMode.CompleteOthers);
    }

}
